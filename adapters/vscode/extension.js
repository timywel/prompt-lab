const vscode = require('vscode');
const path = require('path');
const fs = require('fs');

function activate(context) {
    let disposable = vscode.commands.registerCommand('prompt-lab.showSkills', async () => {
        const skillsDir = path.join(__dirname, 'skills');
        const skillsList = [];

        if (fs.existsSync(skillsDir)) {
            const entries = fs.readdirSync(skillsDir, { withFileTypes: true });
            for (const entry of entries) {
                if (entry.isDirectory()) {
                    const skillPath = path.join(skillsDir, entry.name);
                    const readmePath = path.join(skillPath, 'SKILL.md');
                    let description = entry.name;

                    if (fs.existsSync(readmePath)) {
                        const content = fs.readFileSync(readmePath, 'utf8');
                        const match = content.match(/description:\s*(.+)/);
                        if (match) description = match[1];
                    }

                    skillsList.push({ name: entry.name, description, path: skillPath });
                }
            }
        }

        const items = skillsList.map(s => ({
            label: s.name.replace('prd-', 'PRD: ').replace(/-/g, ' '),
            description: s.description,
            path: s.path
        }));

        const selected = await vscode.window.showQuickPick(items, {
            placeHolder: '选择一个技能查看详情'
        });

        if (selected) {
            const readmePath = path.join(selected.path, 'SKILL.md');
            const doc = await vscode.workspace.openTextDocument(readmePath);
            await vscode.window.showTextDocument(doc);
        }
    });

    context.subscriptions.push(disposable);
}

function deactivate() {}

module.exports = { activate, deactivate };
