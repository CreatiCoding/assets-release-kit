import { Command } from 'clipanion';

export class ProvisionCommand extends Command {
    static paths = [['provision'], ['p']];

    async execute() {
        this.context.stdout.write(`called provision\n`);
    }
}
