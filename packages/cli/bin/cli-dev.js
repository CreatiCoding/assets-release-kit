#!/usr/bin/env node
import { execa } from 'execa';

execa('yarn', ['tsx', './src/cli.ts', ...process.argv.slice(2)], {
    stdio: 'inherit'
});
