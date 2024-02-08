using System;
using Godot;

public partial class SpringArm3D : Godot.SpringArm3D
{

	[Export]
	float MouseSensitivity = 0.05f;

	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		Input.MouseMode = Input.MouseModeEnum.Captured;

	}

	public override void _UnhandledInput(InputEvent input) {
		if(input is InputEventMouseMotion) {
			InputEventMouseMotion MouseEvent  = (InputEventMouseMotion) input;
			float AuxX = RotationDegrees.X;
			float AuxY = RotationDegrees.Y;
			Vector3 NewRotation = new Vector3(
				Math.Clamp(AuxX -= MouseEvent.Relative.Y * MouseSensitivity, -90f, 30f),
				AuxY -= MouseEvent.Relative.X * MouseSensitivity,
				RotationDegrees.Z);

			RotationDegrees = NewRotation;
		}
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
	}
}
