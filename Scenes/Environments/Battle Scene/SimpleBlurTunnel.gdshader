shader_type spatial;
render_mode cull_front;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float lod: hint_range(0.0, 5) = 0.0;

void fragment(){
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, lod);
	ALBEDO = vec3(color.x, color.y, color.z);
	ALPHA = color.w;
	
}