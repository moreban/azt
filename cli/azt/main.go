package main

import (
	"context"
	"os"

	loaders "github.com/hedzr/cmdr-loaders"
	"github.com/hedzr/cmdr/v2"
	"github.com/hedzr/cmdr/v2/cli"
	"github.com/hedzr/cmdr/v2/examples/devmode"
	"github.com/hedzr/cmdr/v2/pkg/logz"
	"github.com/moreban/azt/cli/azt/cmd"
	"github.com/moreban/azt/cli/azt/consts"
)

const (
	appName = consts.AppName
	desc    = consts.Description
	version = consts.Version
	author  = `Azt Authors`
)

func main() {
	ctx := context.Background()
	app := prepareApp(cmd.Commands...) // define your own commands implementations with cmd/*.go
	if err := app.Run(ctx); err != nil {
		logz.ErrorContext(ctx, "Application Error:", "err", err) // stacktrace if in debug mode/build
		os.Exit(app.SuggestRetCode())
	} else if rc := app.SuggestRetCode(); rc != 0 {
		os.Exit(rc)
	}
}

func prepareApp(commands ...cli.CmdAdder) cli.App {
	return loaders.Create(
		appName, version, author, desc,

		cmdr.WithAutoEnvBindings(true),  // default it's false
		cmdr.WithSortInHelpScreen(true), // default it's false
		// cmdr.WithDontGroupInHelpScreen(false), // default it's false

		// can be used for debugging:
		//
		// cmdr.WithTasksBeforeRun(func(ctx context.Context, cmd cli.Cmd, runner cli.Runner, extras ...any) (err error) {
		// 	logz.DebugContext(ctx, "command running...", "cmd", cmd, "runner", runner, "extras", extras)
		// 	return
		// }), // cmdr.WithTasksBeforeParse(), cmdr.WithTasksBeforeRun(), cmdr.WithTasksAfterRun

		// true for debug in developing time, it'll disable onAction on each Cmd.
		// for productive mode, comment this line.
		// The envvars FORCE_DEFAULT_ACTION & FORCE_RUN can override this.
		// cmdr.WithForceDefaultAction(false),
	).
		// importing devmode package and run its init():
		With(func(app cli.App) { logz.Debug("in dev mode?", "mode", devmode.InDevelopmentMode()) }).
		WithBuilders(
		// examples.AddHeadLikeFlagWithoutCmd, // add a `--line` option, feel free to remove it.
		// examples.AddToggleGroupFlags,       //
		// examples.AddTypedFlags,    //
		// examples.AddKilobytesFlag, //
		// examples.AddValidArgsFlag,          //
		).
		WithAdders(commands...).
		Build()
}
