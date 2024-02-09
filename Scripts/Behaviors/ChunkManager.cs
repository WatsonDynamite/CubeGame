using Godot;
using System.Collections.Generic;
using System.Linq;
using System.Threading;

//Taken from xen42's Minecraft Terrain tutorial

public partial class ChunkManager : Node
{
    public static ChunkManager Instance { get; private set; }

    private Dictionary<Chunk, Vector2I> ChunkToPosition = new();
    private Dictionary<Vector2I, Chunk> PositionToChunk = new();

    private List<Chunk> Chunks;

    [Export] public PackedScene ChunkScene { get; set; }

    private int chunkRenderDistance = 8; // _width

    private Vector3 playerPosition;
    private object playerPositionLock = new(); //semaphore

    public override void _Ready()
    {
        Instance = this;
        Chunks = GetParent().GetChildren().Where(child => child is Chunk).Select(child => child as Chunk).ToList();

        for (int i = Chunks.Count; i < chunkRenderDistance * chunkRenderDistance; i++)
        {

            var chunk = ChunkScene.Instantiate<Chunk>();
            GetParent().CallDeferred(Node.MethodName.AddChild, chunk);
            Chunks.Add(chunk);
        }

        for (int x = 0; x < chunkRenderDistance; x++)
        {
            for (int y = 0; y < chunkRenderDistance; y++)
            {
                var index = (y * chunkRenderDistance) + x;
                var halfWidth = Mathf.FloorToInt(chunkRenderDistance / 2f);
                Chunks[index].SetChunkPosition(new Vector2I(x - halfWidth, y - halfWidth));
            }
        }

        if(!Engine.IsEditorHint())
        {
            new Thread(new ThreadStart(ThreadProcess)).Start();
        }
    }

    public void UpdateChunkPosition(Chunk chunk, Vector2I currentPosition, Vector2I previousPosition)
    {
        if (PositionToChunk.TryGetValue(previousPosition, out var ChunkAtPosition) && ChunkAtPosition == chunk)
        {
            PositionToChunk.Remove(previousPosition);
        }

        ChunkToPosition[chunk] = currentPosition;
        PositionToChunk[currentPosition] = chunk;
    }

    public void SetBlock(Vector3I globalPosition, Block block)
    {
        var chunkTilePosition = new Vector2I(Mathf.FloorToInt(globalPosition.X / (float)Chunk.dimensions.X), Mathf.FloorToInt(globalPosition.Z / (float)Chunk.dimensions.Z));
        lock (PositionToChunk)
        {
            if (PositionToChunk.TryGetValue(chunkTilePosition, out var chunk))
            {
                chunk.SetBlock((Vector3I)(globalPosition - chunk.GlobalPosition), block);
            }
        }

    }

    public override void _PhysicsProcess(double delta)
    {
        if (!Engine.IsEditorHint())
        {

            lock (playerPositionLock)
            {
                playerPosition = PlayerMovement2.Instance.GlobalPosition;
            }
        }
    }

    private void ThreadProcess()
    {
        while (IsInstanceValid(this))
        {
            int playerChunkX, playerChunkZ;
            lock (playerPositionLock)
            {
                playerChunkX = Mathf.FloorToInt(playerPosition.X / Chunk.dimensions.X);
                playerChunkZ = Mathf.FloorToInt(playerPosition.Z / Chunk.dimensions.Z);
            }

            foreach (var chunk in Chunks)
            {
                var ChunkPosition = ChunkToPosition[chunk];

                var chunkX = ChunkPosition.X;
                var chunkZ = ChunkPosition.Y;

                var newChunkX = (int)(Mathf.PosMod(chunkX - playerChunkX + chunkRenderDistance / 2, chunkRenderDistance) + playerChunkX - chunkRenderDistance / 2);
                var newChunkZ = (int)(Mathf.PosMod(chunkZ - playerChunkZ + chunkRenderDistance / 2, chunkRenderDistance) + playerChunkZ - chunkRenderDistance / 2);


                if (newChunkX != chunkX || newChunkZ != chunkX)
                {
                    lock (PositionToChunk)
                    {
                        if (PositionToChunk.ContainsKey(ChunkPosition))
                        {
                            PositionToChunk.Remove(ChunkPosition);
                        }

                        var newPosition = new Vector2I (newChunkX, newChunkZ);

                        ChunkToPosition[chunk] = newPosition;
                        PositionToChunk[newPosition] = chunk;

                        chunk.CallDeferred(nameof(Chunk.SetChunkPosition), newPosition);
                    }
                }
            }
        }
    }
}
