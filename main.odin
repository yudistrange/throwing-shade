package main

import rlight "lib/rlight"
import rl "vendor:raylib"

main :: proc() {
	rl.SetConfigFlags({rl.ConfigFlag.VSYNC_HINT, rl.ConfigFlag.BORDERLESS_WINDOWED_MODE})
	rl.InitWindow(1280, 720, "water")
	camera := rl.Camera3D {
		position   = {10, 10, 10},
		target     = {},
		up         = {0, 1, 0},
		fovy       = 45.0,
		projection = rl.CameraProjection.PERSPECTIVE,
	}

	model := rl.LoadModelFromMesh(rl.GenMeshTorus(0.4, 5, 32, 64))
	defer rl.UnloadModel(model)

	shader := rl.LoadShader(
		"resources/shaders/lighting_vertex.glsl",
		"resources/shaders/lighting_frag.glsl",
	)

	view_pos := rl.GetShaderLocation(shader, "viewPos")

	// Set Ambient light level
	ambient_light_loc: rl.Vector4 = {0.2, 0.2, 0.2, 1.0}
	ambient_loc := rl.GetShaderLocation(shader, "ambient")

	rl.SetShaderValue(shader, ambient_loc, &ambient_light_loc, rl.ShaderUniformDataType.VEC4)

	// Set 1 point light
	light := rlight.create_light(rlight.LightType.POINT, {0, 2, 6}, {0, 0, 0}, rl.WHITE, shader)
	rlight.update_light_values(shader, light)

	rl.SetTargetFPS(120)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		rl.ClearBackground(rl.BLANK)

		dt := rl.GetFrameTime()

		model.transform = model.transform * rl.MatrixRotateX(1 * dt)

		rl.SetShaderValue(shader, view_pos, &camera.position, rl.ShaderUniformDataType.VEC3)

		rl.BeginMode3D(camera)
		rl.DrawModel(model, rl.Vector3{}, 1.0, rl.PINK)
		rl.EndMode3D()

		rl.DrawFPS(10, 10)
		rl.EndDrawing()
	}
	rl.CloseWindow()
}
