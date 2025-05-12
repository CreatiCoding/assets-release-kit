import { Cli, Builtins } from 'clipanion';
import { ProvisionCommand } from './commands/ProvisionCommand/index.js';
import pkg from '../package.json' with { type: 'json' };

const cli = new Cli({
    binaryLabel: pkg.name,
    binaryName: `yarn ${Object.keys(pkg.bin)[0]}`,
    binaryVersion: pkg.version,
});

cli.register(Builtins.HelpCommand);
cli.register(Builtins.VersionCommand);
cli.register(ProvisionCommand);

export { cli, ProvisionCommand };
