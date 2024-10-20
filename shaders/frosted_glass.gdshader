shader_type spatial;
//render_mode cull_disabled;
render_mode blend_mix,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx, unshaded;

/*
Original Shader obtained from...
https://godotshaders.com/shader/frosted-glass/
https://godotshaders.com/shader/improved-frosted-glass/
*/

uniform float distortion_size = 0.4;
uniform vec4 tint : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D depth_texture : hint_depth_texture, source_color;
uniform sampler2D glass;

void fragment() {
	vec2 d = texture(glass, UV).xy - vec2(0.5);
	float dtd = sqrt(texture(depth_texture, UV).r);
	vec3 gcolor = texture(screen_texture, SCREEN_UV + d * distortion_size * dtd).rgb * 0.9 + vec3(0.1);
	ALBEDO = gcolor * tint.rgb;
	ALPHA = 0.99;
}