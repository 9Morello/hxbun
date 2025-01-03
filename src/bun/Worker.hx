package bun;

import js.Syntax;
import js.html.Worker;

/**
    Create a new WebWorker that has the same entrypoint as your Haxe program.
    You can customize its behavior by checking for `Bun.isMainThread` inside your `main` function.
    If `Bun.isMainThread` is `true`, that means the code is running inside a worker thread, and you
    can access the `bun.Worker.Self` class to add event listeners.
**/
@:forward abstract HxbunWorker(Worker) {
    public function new(?options:WorkerOptions) {
        this = Syntax.code('new Worker(new URL(import.meta.file, import.meta.url).href, {0});', options);
    }
}

/**
    Create a regular JavaScript Web Worker. Instead of using your Haxe program as the worker's entrypoint,
    you can use any JavaScript or TypeScript file. This is useful if you want to load JS/TS directly, or if
    you have a separate Haxe-to-JS compile step for your worker code, and that code ends in a separate file.
**/
abstract JavaScriptWorker(Worker) {
    public function new(modulePath:String, ?options:WorkerOptions) {
        this = Syntax.code('new Worker({0}, {1})', modulePath, options);
    }
}

@:native("self") extern final Self:Worker;

typedef WorkerOptions = {
    ?name: String,
    /**
    * Use less memory, but make the worker slower.
    *
    * Internally, this sets the heap size configuration in JavaScriptCore to be
    * the small heap instead of the large heap.
    */
    ?smol: Bool,
      /**
       * When `true`, the worker will keep the parent thread alive until the worker is terminated or `unref`'d.
       * When `false`, the worker will not keep the parent thread alive.
       *
       * By default, this is `false`.
       */
    ?ref: Bool,

    /**
       * List of arguments which would be stringified and appended to
       * `Bun.argv` / `process.argv` in the worker. This is mostly similar to the `data`
       * but the values will be available on the global `Bun.argv` as if they
       * were passed as CLI options to the script.
    */
    ?argv: Array<String>,
}
