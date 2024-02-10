using System;
using Godot;

public partial class PlayerMovement2 : CharacterBody3D
{	
	[Export] public const float Speed = 10.0f;
	[Export] public const float JumpVelocity = 10f;
	[Export] public const float Friction = 6f;

	[Export] public const float Acceleration = 4f;
	[Export] public const float AirAccel = 3f;
	[Export] public const float TurnAccel = 10f;

	// Get the gravity from the project settings to be synced with RigidBody nodes.
	public float gravity = ProjectSettings.GetSetting("physics/3d/default_gravity").AsSingle();

	public SpringArm3D SpringArm;
	public Node3D Model;

	public Node3D BodyBone;

	public AnimationTree AnimTree;
	public override void _Ready() {

		SpringArm = GetNode("CameraPivot/CameraArm") as SpringArm3D;
		SpringArm.AddExcludedObject(GetRid());
		Model = GetNode<Node3D>("Model");
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
		//we convert the velocity value to a value between 0 and 1 by dividing the absolute by our speed constant

		AnimTree.Set("parameters/Movement/blend_position", Math.Abs(Velocity.Length() / Speed));

		MoveAndSlide();


		if(new Vector2(AuxVelocity.X, AuxVelocity.Z).Length() > 0.2f) {

			/*Code for various player model rotations
				- The player model needs to turn to face the movement direction
				- However we also have a cosmetic tilt of the character's body when the player turns
					- to do this, we rotate the body bone around the Z axis in the angle formed by the model's current forward
						and the movement vector's forward
					- we need to make a copy of the movement vector with no Y axis to make it always face upward
						otherwise the simple act of falling will cause the player to tilt as the velocity vector will have a 180 degree angle with the
						model's forward vector
			*/

			Vector3 AuxVelocityFacingUp = new Vector3(AuxVelocity.X, 0, AuxVelocity.Z);
			//Angle in degrees between the movement direction and the model's forward direction
			//We clamp the angle because we don't want more than a 30 degree tilt
			float DirectionAngle = Math.Clamp(Mathf.RadToDeg(AuxVelocityFacingUp.SignedAngleTo(Model.GlobalBasis.Z, Vector3.Up)), -30, 30);
			//Amount to tilt the player model
			float TiltLerpAngle = Mathf.LerpAngle(Model.Rotation.Z, Mathf.DegToRad(DirectionAngle), (float) (delta * TurnAccel));

			//rotate player model
			Model.Rotation =  new Vector3(
			Model.Rotation.X, //X
			Mathf.LerpAngle(Model.Rotation.Y, (float) Math.Atan2(AuxVelocity.X, AuxVelocity.Z), (float) (delta * TurnAccel)), //Y
			TiltLerpAngle //Z
			);
			
		}
	}
}
