using System;
using Godot;

public partial class PlayerMovement2 : CharacterBody3D
{
	[Export] public const float Speed = 5.0f;
	[Export] public const float JumpVelocity = 10f;
	[Export] public const float Friction = 6f;

	[Export] public const float Acceleration = 8f;
	[Export] public const float AirAccel = 3f;
	[Export] public const float TurnAccel = 10f;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle();

	public SpringArm3D SpringArm;
	public Node3D AnimSkeleton;

	public Node3D BodyBone;

	public AnimationTree AnimTree;
	public override void _Ready() {
		SpringArm = GetNode("CameraPivot/CameraArm") as SpringArm3D;
		SpringArm.AddExcludedObject(GetRid());
		AnimSkeleton = GetNode<Node3D>("Model");
		BodyBone = GetNode<Node3D>("Model/Body");
		AnimTree = GetNode<AnimationTree>("AnimationTree");
	}


	public override void _PhysicsProcess(double delta)
	{
		Vector3 AuxVelocity = Velocity;
		float UseAcceleration;

		// Add the gravity.
		if (!IsOnFloor()) {
			AnimTree.Active = false;
			AuxVelocity.Y -= gravity * (float)delta;
			UseAcceleration = AirAccel;
		} else {
			AnimTree.Active = true;
			UseAcceleration = Acceleration;
		}


		// Handle Jump.
		if (Input.IsActionJustPressed("ui_accept") && IsOnFloor())
			AuxVelocity.Y = JumpVelocity;

		// Get the input direction and handle the movement/deceleration.
		// As good practice, you should replace UI actions with custom gameplay actions.
		Vector2 inputDir = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
		Vector3 direction = (SpringArm.Basis * new Vector3(inputDir.X, 0, inputDir.Y)).Normalized();
		
		AuxVelocity.X = (float) Mathf.Lerp(AuxVelocity.X, direction.Normalized().X * Speed, UseAcceleration * delta);
		AuxVelocity.Z = (float) Mathf.Lerp(AuxVelocity.Z, direction.Normalized().Z * Speed, UseAcceleration * delta);

		Velocity = AuxVelocity;

		//set animation on blend tree
		
		//calculate body tilting direction: get angle between player body and movement direction
		//also, normalize this to [-1;1] by dividing by 90
		var AnimSkeletonForward = AnimSkeleton.GlobalTransform.Basis.Z;
		var degree = Velocity.AngleTo(AnimSkeletonForward) / 90;
		GD.Print(AnimSkeleton.GlobalTransform.Basis.Z);
	
		AnimTree.Set("parameters/blend_position", new Vector2(Velocity.X, degree));


		MoveAndSlide();

		if(new Vector2(AuxVelocity.X, AuxVelocity.Z).Length() > 0.2f) {
			//rotate player model
			AnimSkeleton.Rotation =  new Vector3(
			AnimSkeleton.Rotation.X, //X
			Mathf.LerpAngle(AnimSkeleton.Rotation.Y, (float) Math.Atan2(AuxVelocity.X, AuxVelocity.Z), (float) (delta * TurnAccel)), //Y
			AnimSkeleton.Rotation.Z //Z
			);
			
		}
	}
}
