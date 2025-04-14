// https://godotshaders.com/shader/directional-sound-hud-element/
shader_type canvas_item;
uniform float inner_diameter:hint_range(0,.5) = .25;
uniform float outer_diameter:hint_range(0,.5) = .3;
uniform sampler2D noise; // Noise texture
uniform sampler2D sounds; // Curve texture
uniform float noise_strength = .1;
uniform float noise_speed = .1;
uniform vec4 foreground = vec4(1.);
uniform vec4 background = vec4(0.);

void fragment() {
    // Get the angle from the UV to the center, in radians.
    float angle = atan(UV.y - 0.5, UV.x - 0.5);
    // Ensure we don't have negative values.
    angle = abs(angle + PI);
    // Make it a value from 0-1
    angle /= PI * 2.;

    // This value makes the noise wobble!
    float shake = fract(TIME * noise_speed);
    // Sample the noise texture for our wobble.
    float noise_value = texture(noise, vec2(shake, angle)).r;
    // Sample our sound texture for the sound direction
    float sound_value = texture(sounds, vec2(angle)).r;
    // Get our distance from the center
    float dist = distance(UV, vec2(0.5));
    // Apply the noise, by the sound amount, and scale to the strength
    dist -= noise_value * sound_value * noise_strength;
    // Construct the ring
    float inner = step(inner_diameter, dist);
    float outer = 1. - step(outer_diameter, dist);
    dist = inner * outer;
    // Use our distance value to apply foreground color, drawing our wobbly circle.
    vec4 final_color = mix(foreground, background, 1.0 - dist);

    // Apply modulate and self_modulate
    COLOR = final_color * COLOR;
}
