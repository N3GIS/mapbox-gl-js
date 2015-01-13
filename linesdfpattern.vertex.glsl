// floor(127 / 2) == 63.0
// the maximum allowed miter limit is 2.0 at the moment. the extrude normal is
// stored in a byte (-128..127). we scale regular normals up to length 63, but
// there are also "special" normals that have a bigger length (of up to 126 in
// this case).
// #define scale 63.0
#define scale 0.015873016

attribute vec2 a_pos;
attribute vec4 a_data;

// matrix is for the vertex position, exmatrix is for rotating and projecting
// the extrusion vector.
uniform mat4 u_matrix;
uniform mat4 u_exmatrix;

uniform vec2 u_linewidth;
uniform float u_ratio;
uniform vec2 u_patternscale;
uniform float u_tex_y;

varying vec2 v_normal;
varying float v_linesofar;
varying vec2 v_tex;

void main() {
    vec2 a_extrude = a_data.xy;
    float a_linesofar = a_data.z * 128.0 + a_data.w;

    // We store the texture normals in the most insignificant bit
    // transform y so that 0 => -1 and 1 => 1
    // In the texture normal, x is 0 if the normal points straight up/down and 1 if it's a round cap
    // y is 1 if the normal points up, and -1 if it points down
    vec2 normal = mod(a_pos, 2.0);
    normal.y = sign(normal.y - 0.5);
    v_normal = normal;

    // Scale the extrusion vector down to a normal and then up by the line width
    // of this vertex.
    vec4 dist = vec4(u_linewidth.s * a_extrude * scale, 0.0, 0.0);

    // Remove the texture normal bit of the position before scaling it with the
    // model/view matrix. Add the extrusion vector *after* the model/view matrix
    // because we're extruding the line in pixel space, regardless of the current
    // tile's zoom level.
    gl_Position = u_matrix * vec4(floor(a_pos * 0.5), 0.0, 1.0) + u_exmatrix * dist;
    v_linesofar = a_linesofar * u_ratio;

    v_tex = vec2(a_linesofar * u_patternscale.x, normal.y * u_patternscale.y + u_tex_y);
    //v_tex = vec2(a_linesofar, 1.0);
    //v_tex = vec2(1.0, 1.0);
}
