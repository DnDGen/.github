# Building and releasing a DnDGen library

Every DnDGen NuGet library builds and releases the same way, so the workflows live here, in
[.github/workflows](../.github/workflows), and each library calls them from two short files of
its own.

| Shared workflow | What it does |
|---|---|
| [nuget-build.yml](../.github/workflows/nuget-build.yml) | Checks the csproj `<Version>` is greater than every release, builds the library, runs its tests with coverage, checks coverage is no lower than the latest release's, and uploads the package and the coverage report |
| [nuget-release.yml](../.github/workflows/nuget-release.yml) | Pushes the package to nuget.org with Trusted Publishing, then tags the commit and creates the GitHub release with the package and coverage report attached |

The scripts behind those checks are in [scripts](../scripts), with their Pester tests. This
repository's [CI](../.github/workflows/ci.yml) runs those tests, so the libraries don't.

## Adopting them in a library

1. Copy [build.yml](build.yml) and [release.yml](release.yml) to the library's
   `.github/workflows`, and replace `DnDGen.YourGen` with the library's project name.
2. Copy [CodeCoverage.runsettings](CodeCoverage.runsettings) to the library's root, and replace
   `DnDGen\.YourGen` with the library's project name, dots escaped. It stays in the library
   because `dotnet test --settings CodeCoverage.runsettings` uses it locally too.
3. Make sure the latest GitHub release has a `coverage.cobertura.xml` attached. The coverage
   check fails without one to compare against.
4. In the library's settings, create a `Prod` environment, and require the `build / check`
   status check on `main`.
5. On nuget.org, add a Trusted Publishing policy for the library's repository, with
   `release.yml` as the workflow file and `Prod` as the environment.
6. Delete the library's old pipelines (`cicd/`, or `.github/scripts` and its own build steps).

## The layout they expect

- The library's project is `<project>/<project>.csproj`, with its `<Version>` in the csproj.
- Its tests are split into these tiers, each a folder holding a csproj of the same name. Each
  tier is its own step, and they run in this order, fastest first, so a failing tier stops the
  slower ones after it:

  | Step | Test project | Configuration |
  |---|---|---|
  | Unit tests | `<project>.Tests.Unit` | Debug |
  | IoC tests | `<project>.Tests.Integration.IoC` | Debug |
  | Table tests | `<project>.Tests.Integration.Tables` | Debug |
  | Integration tests | `<project>.Tests.Integration` | Debug |
  | Stress tests | `<project>.Tests.Integration.Stress` | Stress |

- A library without one of those tiers shows its step as skipped. A test project outside these
  tiers doesn't run, so a new tier starts here, in `nuget-build.yml`, for every library at once.

## Versions

Libraries call the workflows at `@v1`. A change that keeps every library working moves the
`v1` tag forward; a change that breaks a caller starts `v2`. `nuget-build.yml` checks out the
scripts at its `tooling-ref` input, which defaults to `v1` too. To try a change from a branch,
point a library's `uses:` at the branch and pass the same branch as `tooling-ref`.
