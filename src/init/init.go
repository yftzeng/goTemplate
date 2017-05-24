package init

import "github.com/go-ini/ini"

func init() {
	config, err := ini.Load([]byte(""), "config/config.ini")
	if err != nil {
		panic(err)
	}

	initLog(config)
	initDB(config)
}
