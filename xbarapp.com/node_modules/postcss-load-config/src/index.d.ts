// based on @types/postcss-load-config@2.0.1
// Type definitions for postcss-load-config 2.1
import Processor from 'postcss/lib/processor'
import { Plugin, ProcessOptions, Transformer } from "postcss";
import { Options as CosmiconfigOptions } from 'cosmiconfig';

// In the ConfigContext, these three options can be instances of the
// appropriate class, or strings. If they are strings, postcss-load-config will
// require() them and pass the instances along.
interface ProcessOptionsPreload {
    parser?: string | ProcessOptions['parser'];
    stringifier?: string | ProcessOptions['stringifier'];
    syntax?: string | ProcessOptions['syntax'];
}

// The remaining ProcessOptions, sans the three above.
type RemainingProcessOptions =
    Pick<ProcessOptions, Exclude<keyof ProcessOptions, keyof ProcessOptionsPreload>>;

// Additional context options that postcss-load-config understands.
interface Context {
    cwd?: string;
    env?: string;
}

// The full shape of the ConfigContext.
type ConfigContext = Context & ProcessOptionsPreload & RemainingProcessOptions;

// Result of postcssrc is a Promise containing the filename plus the options
// and plugins that are ready to pass on to postcss.
type ResultPlugin = Plugin | Transformer | Processor;

interface Result {
    file: string;
    options: ProcessOptions;
    plugins: ResultPlugin[];
}

declare function postcssrc(ctx?: ConfigContext, path?: string, options?: CosmiconfigOptions): Promise<Result>;

declare namespace postcssrc {
    function sync(ctx?: ConfigContext, path?: string, options?: CosmiconfigOptions): Result;
}

export = postcssrc;
