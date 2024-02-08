using Godot;
using System;

public partial class PlayerMovement : CharacterBody3D
{
	public const float Speed = 5.0f;
	public const float JumpVelocity = 10.0f;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle();

	public SpringArm3D SpringArm;
	public Node3D AnimSkeleton;
	public override void _Ready() {
		SpringArm = GetNode("SpringArm3D") as SpringArm3D;
		AnimSkeleton = GetNode<Node3D>("/AnimSkeleton");
	}

	public override void _Process(double delta) {
		SpringArm.Position = Position;
	}
	public override void _PhysicsProcess(double delta)
	{
		Vector3 velocity = Velocity;

		// Add the gravity.
		if (!IsOnFloor())
			velocity.Y -= gravity * (float)delta;

		// Handle Jump.
		if (Input.IsActionJustPressed("ui_accept") && IsOnFloor())
			velocity.Y = JumpVelocity;


		Vector3 MoveDirection = Vector3.Zero;

		MoveDirection.X = Input.GetActionStrength("ui_right") - Input.GetActionStrength("ui_left");
		MoveDirection.Z = Input.GetActionStrength("ui_down") - Input.GetActionStrength("ui_up");
		
		MoveDirection = MoveDirection.Rotated(Vector3.Up, SpringArm.Rotation.Y).Normalized();
		
		GD.Print(velocity);

		velocity.X = MoveDirection.X * Speed;
		velocity.Z = MoveDirection.Z * Speed;
		velocity.Y -= (float) gravity * (float) delta;

		Velocity = velocity;
		MoveAndSlide();

		if(velocity.Length() > 0.2f) {
			Vector2 LookDirection = new Vector2(velocity.Z, velocity.X);
			AnimSkeleton.Rotation = new Vector3(AnimSkeleton.Rotation.X, LookDirection.Angle(), AnimSkeleton.Rotation.Z);
		}
	}
}
