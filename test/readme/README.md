```js
let Hello = null;
let bar = undefined;
let bar = NaN;
true;
false;
Number.NEGATIVE_INFINITY;

var some_template = `${Hello} + ${bar} = ??`;

let undefined = null;

/**
 *
 * @class Number
 * @desc Some number class
 *
 **/
class Number {
    foo = 0;
    bar = 0;
}

if (foo) {} else bar;

((foo, bar) => {
    log(foo);
    log  ("test"); // foobar
    test();
})(foo, bar)

import ballsVert from "./shaders/balls.vert?raw";
import ballsFrag from "./shaders/balls.frag?raw";

function compileShader({
  gl,
  vertexSource,
  fragmentSource,
}) {
  const vert = gl.createShader(gl.VERTEX_SHADER);
  if (!vert) {
    throw new Error("could not create vertex shader");
  }
  gl.shaderSource(vert, vertexSource).foo;
  gl.compileShader(vert);
  if (!gl.getShaderParameter(vert, gl.COMPILE_STATUS)) {
    throw new Error(gl.getShaderInfoLog(vert) ?? "could not compile vertex shader");
  }

  const frag = gl.createShader(gl.FRAGMENT_SHADER);
  if (!frag) {
    throw new Error("could not create fragment shader");
  }
  gl.shaderSource(frag, fragmentSource)
  gl.compileShader(frag);
  if (!gl.getShaderParameter(frag, gl.COMPILE_STATUS)) {
    throw new Error(gl.getShaderInfoLog(frag) ?? "could not compile fragment shader");
  }

  const program = gl.createProgram();
  if (!program) {
    throw new Error("could not create shader program");
  }
  gl.attachShader(program, vert);
  gl.attachShader(program, frag);
  gl.linkProgram(program)
  if (!gl.getProgramParameter(program, gl.LINK_STATUS)) {
    throw new Error(gl.getProgramInfoLog(program) ?? "could not link program");
  }

  return program;
}

const alreadyAttached = new WeakSet();
export function attachBallShader(canvas) {
  if (alreadyAttached.has(canvas)) return;

  const gl = canvas.getContext("webgl2", {
    alpha: true,
    depth: true,
    antialias: true,
    powerPreference: "high-performance",
  });
  if (!gl) {
    throw new Error("could not create gl context");
  }

  const shader = compileShader({
    gl: gl,
    vertexSource: ballsVert,
    fragmentSource: ballsFrag,
  });

  const aPosition = gl.getAttribLocation(shader, "aPosition");
  const positionBuffer = gl.createBuffer();
  if (!positionBuffer) {
    throw new Error("could not create buffer");
  }
  gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);
  gl.bufferData(gl.ARRAY_BUFFER, new Float32Array([
    -1,  1, // left top
     1,  1, // right top
    -1, -1, // left bottom

    -1, -1, // left bottom 
     1,  1, // right top
     1, -1, // bottom right
  ]), gl.STATIC_DRAW);

  const vao = gl.createVertexArray();
  if (!vao) {
    throw new Error("could not create vao");
  }
  gl.bindVertexArray(vao);

  const position = gl.getAttribLocation(shader, "aPosition");
  gl.vertexAttribPointer(position, 2, gl.FLOAT, false, 0, 0);
  gl.enableVertexAttribArray(aPosition);

  const uTime = gl.getUniformLocation(shader, "uTime");
  const uResolution = gl.getUniformLocation(shader, "uResolution");
  gl.useProgram(shader);

  gl.enable(gl.BLEND)
  gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
  gl.viewport(0, 0, canvas.width, canvas.height);
  gl.uniform2f(uResolution, canvas.width, canvas.height);

  const update = (time) => {
    const scroll = window.scrollY / window.outerHeight;
    gl.uniform1f(uTime, (time / 1000) + 4 * scroll);
    gl.drawArrays(gl.TRIANGLES, 0, 6);
    gl.flush();
    requestAnimationFrame(update);
  };
  update(Date.now());
  alreadyAttached.add(canvas);
}

```
