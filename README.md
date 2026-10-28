# claude-config

Mes skills Claude Code, pour les retrouver dans les sessions cloud.

- `skills/` (15) : graphify, ponytail (6), hallmark, UI UX Pro Max (7)
- `hooks-src/ponytail/` : hooks ponytail (mode actif au démarrage, sous-agents, niveaux)
- `CLAUDE.md` : déclencheur `/graphify`
- `setup-cloud.sh` : copie tout dans `~/.claude`, installe graphify, ajoute les hooks

## Environnement cloud

Dans les réglages de l'environnement cloud (claude.ai/code), script de démarrage :

```bash
git clone --depth 1 https://github.com/YannisParuta/claude-config /tmp/claude-config && bash /tmp/claude-config/setup-cloud.sh
```

## Mettre à jour

Le PC Windows est la référence (`~/.claude`). Pour reprendre ses skills ici :

```bash
cd ~/.claude && tar cf - --exclude=skills/synced skills hooks-src CLAUDE.md | tar xf - -C ~/code/claude-config
```

## Licences

Les skills viennent de projets libres, licences dans `licenses/` :
graphify (Apache 2.0, Graphify-Labs/graphify), ponytail (MIT, DietrichGebert/ponytail),
hallmark (MIT, nutlope/hallmark), UI UX Pro Max (MIT, nextlevelbuilder/ui-ux-pro-max-skill).
