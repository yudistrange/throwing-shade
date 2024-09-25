package rlight

import "core:c"
import rl "vendor:raylib"

LightType :: enum {
	DIRECTIONAL,
	POINT,
}

Light :: struct {
	type:           c.int,
	enabled:        c.int,
	position:       [3]c.float,
	target:         [3]c.float,
	color:          rl.Color,
	attenuation:    f32,

	// Shader locations
	enabledLoc:     c.int,
	typeLoc:        c.int,
	positionLoc:    c.int,
	targetLoc:      c.int,
	colorLoc:       c.int,
	attenuationLoc: c.int,
}

create_light :: proc(
	type: LightType,
	position: rl.Vector3,
	target: rl.Vector3,
	color: rl.Color,
	shader: rl.Shader,
) -> Light {
	light := Light {
		enabled  = 1,
		type     = 0 if type == LightType.POINT else 1,
		position = position,
		target   = target,
		color    = color,
	}

	// NOTE: Lighting shader naming must be the provided ones
	light.enabledLoc = rl.GetShaderLocation(shader, cstring("light.enabled"))
	light.typeLoc = rl.GetShaderLocation(shader, "light.type")
	light.positionLoc = rl.GetShaderLocation(shader, "light.position")
	light.targetLoc = rl.GetShaderLocation(shader, "light.target")
	light.colorLoc = rl.GetShaderLocation(shader, "light.color")

	return light
}

update_light_values :: proc(shader: rl.Shader, light: Light) {
	// Send to shader light enabled state and type
	light_type: c.int = light.type
	light_enabled: c.int = light.enabled

	rl.SetShaderValue(shader, light.enabledLoc, &light_enabled, rl.ShaderUniformDataType.INT)
	rl.SetShaderValue(shader, light.typeLoc, &light_type, rl.ShaderUniformDataType.INT)

	// Send to shader light position values
	position: [3]c.float = {light.position.x, light.position.y, light.position.z}
	rl.SetShaderValue(shader, light.positionLoc, &position, rl.ShaderUniformDataType.VEC3)

	// Send to shader light target position values
	target: [3]c.float = {light.target.x, light.target.y, light.target.z}
	rl.SetShaderValue(shader, light.targetLoc, &target, rl.ShaderUniformDataType.VEC3)

	// Send to shader light color values
	color: [4]c.float = {
		c.float(light.color.r) / 255.0,
		c.float(light.color.g) / 255.0,
		c.float(light.color.b) / 255.0,
		c.float(light.color.a) / 255.0,
	}

	rl.SetShaderValue(shader, light.colorLoc, &color, rl.ShaderUniformDataType.VEC4)
}
