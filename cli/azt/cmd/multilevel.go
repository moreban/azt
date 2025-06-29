package cmd

import (
	"context"
	"os"

	"github.com/hedzr/cmdr/v2/cli"
	"github.com/hedzr/cmdr/v2/pkg/logz"
	"github.com/hedzr/is"
	origlogz "github.com/hedzr/logg/slog"
)

type multiCmd struct{}

func (multiCmd) Add(app cli.App) {
	if is.DebuggerAttached() {
		logz.SetLevel(origlogz.TraceLevel)
		app.WithOpts(cli.WithArgs(os.Args[0], "~~tree"))
	}
	app.Cmd("multi", "m", "").
		Description("multi-level test and imported form struct").
		// Group("Test").
		TailPlaceHolders("[text1, text2, ...]").
		OnAction(soundex).
		FromStruct(root{}).
		With(func(b cli.CommandBuilder) {
			// b.FromStruct(&root{})
		})
}

type root struct {
	b   bool // unexported values ignored
	Int int  `cmdr:"-"` // ignored
	A   `title:"a-cmd" shorts:"a,a1,a2" alias:"a1-cmd,a2-cmd" desc:"A command for demo" required:"true"`
	B
	C
	F1 int
	F2 string
}

type A struct {
	D
	F1 int
	F2 string
}
type B struct {
	F2 int
	F3 string
}
type C struct {
	F3 bool
	F4 string
}
type D struct {
	E
	FromNowOn F
	F3        bool
	F4        string
}
type E struct {
	F3 bool `title:"f3" shorts:"ff" alias:"f3ff" desc:"A flag for demo" required:"true"`
	F4 string
}
type F struct {
	F5 uint
	F6 byte
}

// a --f1 1 --f2 str
// --a.f1 1 --a.f2 str

func (A) With(cb cli.CommandBuilder) {
	// customize for A command, for instance: fb.ExtraShorts("ff")
	logz.Info(".   - A.With() invoked.", "cmdbuilder", cb)
}
func (A) F1With(fb cli.FlagBuilder) {
	// customize for A.F1 flag, for instance: fb.ExtraShorts("ff")
	logz.Info(".   - A.F1With() invoked.", "flgbuilder", fb)
}

// Action method will be called if end-user type subcmd for it (like `app a d e --f3`).
func (E) Action(ctx context.Context, cmd cli.Cmd, args []string) (err error) {
	logz.Info(".   - E.Action() invoked.", "cmd", cmd, "args", args)
	_, err = cmd.App().DoBuiltinAction(ctx, cli.ActionDefault, stringArrayToAnyArray(args)...)
	return
}

// Action method will be called if end-user type subcmd for it (like `app a d f --f5=7`).
func (s F) Action(ctx context.Context, cmd cli.Cmd, args []string) (err error) {
	(&s).Inc()
	logz.Info(".   - F.Action() invoked.", "cmd", cmd, "args", args, "F5", s.F5)
	_, err = cmd.App().DoBuiltinAction(ctx, cli.ActionDefault, stringArrayToAnyArray(args)...)
	return
}

func (s *F) Inc() {
	s.F5++
}

func stringArrayToAnyArray(args []string) (ret []any) {
	for _, it := range args {
		ret = append(ret, it)
	}
	return
}
