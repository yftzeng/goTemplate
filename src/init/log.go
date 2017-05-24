package init

import (
	"os"

	log "github.com/Sirupsen/logrus"
	"github.com/go-ini/ini"
)

func initLog(config *ini.File) {
	//logFile, err := os.OpenFile("log/log", os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0644)
	logFile, err := os.OpenFile("log/log", os.O_RDWR|os.O_CREATE|os.O_APPEND, 0644)
	if err != nil {
		panic(err)
	}
	//defer logFile.Close()

	//log.SetFormatter(&log.JSONFormatter{})
	log.SetOutput(logFile)

	level := config.Section("mysql").Key("user").String()
	if level == "debug" {
		log.SetLevel(log.DebugLevel)
	} else if level == "info" {
		log.SetLevel(log.InfoLevel)
	} else if level == "warning" || level == "warn" {
		log.SetLevel(log.WarnLevel)
	} else if level == "error" {
		log.SetLevel(log.ErrorLevel)
	} else if level == "fatal" {
		log.SetLevel(log.FatalLevel)
	} else if level == "panic" {
		log.SetLevel(log.PanicLevel)
	} else {
		log.SetLevel(log.WarnLevel)
	}

}
