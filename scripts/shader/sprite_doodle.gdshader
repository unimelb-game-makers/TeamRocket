shader_type canvas_item;

uniform float wobble_amount : hint_range(0.0, 10.0) = 1.0;
uniform float speed : hint_range(0.1, 10.0) = 1.0;
uniform float frame_rate : hint_range(1.0, 60.0) = 3.0; // Controls the choppy effect

// Vertex shader
void vertex() {
    // Use time and vertex position to generate a random displacement
    float stepped_time = floor(TIME * frame_rate) / frame_rate;

    // Generate random offsets based on the vertex position and time
    vec2 random_offset = vec2(
        fract(sin(dot(VERTEX.xy, vec2(12.9898, 78.233))) * 43758.5453123 + stepped_time * speed) - 0.5,
        fract(sin(dot(VERTEX.xy, vec2(39.346, 11.234))) * 43758.5453123 + stepped_time * speed) - 0.5
    ) * wobble_amount; // Apply the wobble amount to the offset

    // Displace the vertex position by the random offset
    VERTEX.xy += random_offset;
}

// Fragment shader
void fragment() {
    vec2 uv = UV;

    // Sample the texture with the modified UVs
    vec4 tex_color = texture(TEXTURE, uv);

    // Apply the texture color to the fragment
    COLOR = tex_color;
}
