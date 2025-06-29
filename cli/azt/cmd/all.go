package cmd

import (
	"github.com/hedzr/cmdr/v2/cli"
)

var Commands = // append(
[]cli.CmdAdder{
	&multiCmd{},
	sndx{},
	wrongCmd{},
} //,
// cmd.Commands...,
// )
