using Godot;
using System;

public partial class PlayerMovement2 : CharacterBody3D
{
	public const float Speed = 5.0f;
	public const float JumpVelocity = 4.5f;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle();

	public Godot.SpringArm3D SpringArm;
	public Node3D AnimSkeleton;
	public override void _Ready() {
		SpringArm = GetNode("CameraPivot/CameraArm") as Godot.SpringArm3D;
		GD.Print(SpringArm);
		AnimSkeleton = GetNode<Node3D>("Model");
		GD.Print(AnimSkeleton);
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

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		Vector2 inputDir = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
		Vector3 direction = (SpringArm.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();
		if (direction != Vector3.Zero)
		{
			velocity.X = direction.X * Speed;
			velocity.Z = direction.Z * Speed;
		}
		else
		{
			velocity.X = Mathf.MoveToward(Velocity.X, 0, Speed);
			velocity.Z = Mathf.MoveToward(Velocity.Z, 0, Speed);
		}

		Velocity = velocity;
		MoveAndSlide();

		if(velocity.Length() > 0.2f) {
			Vector2 LookDirection = new Vector2(velocity.Z, velocity.X);
			AnimSkeleton.Rotation = new Vector3(AnimSkeleton.Rotation.X, LookDirection.Angle(), AnimSkeleton.Rotation.Z);
		}
	}
}
