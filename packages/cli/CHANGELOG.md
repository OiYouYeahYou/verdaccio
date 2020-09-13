# @verdaccio/cli

## 5.0.0-alpha.1
### Minor Changes

- 26b494cb: feat: add typescript project references settings
  
  Reading https://ebaytech.berlin/optimizing-multi-package-apps-with-typescript-project-references-d5c57a3b4440 I realized I can use project references to solve the issue to pre-compile modules on develop mode.
  
  It allows to navigate (IDE) trough the packages without need compile the packages.
  
  Add two `tsconfig`, one using the previous existing configuration that is able to produce declaration files (`tsconfig.build`) and a new one `tsconfig` which is enables [_projects references_](https://www.typescriptlang.org/docs/handbook/project-references.html).

### Patch Changes

- b57b4338: Enable prerelease mode with **changesets**
- Updated dependencies [26b494cb]
- Updated dependencies [b57b4338]
  - @verdaccio/config@5.0.0-alpha.1
  - @verdaccio/logger@5.0.0-alpha.1
  - @verdaccio/node-api@5.0.0-alpha.1
  - @verdaccio/utils@5.0.0-alpha.1
