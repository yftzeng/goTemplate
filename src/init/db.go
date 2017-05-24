package init

import (
	"database/sql"
	"time"

	"github.com/go-ini/ini"
)

var (
	// DbConfig : DbConfigStruct
	DbConfig DbConfigStruct
)

// DbConfigStruct : read database config in memory
type DbConfigStruct struct {
	User            string
	Password        string
	Address         string
	Port            string
	Database        string
	Charset         string
	Collation       string
	ConnMaxLifeTime time.Duration
	MaxIdleConns    int
	MaxOpenConns    int
}

func initDB(config *ini.File) {

	maxLifeTime, _ := config.Section("mysql").Key("maxlifetime").Int()
	maxIdleConns, _ := config.Section("mysql").Key("maxidleconns").Int()
	maxOpenConns, _ := config.Section("mysql").Key("maxopenconns").Int()

	DbConfig = DbConfigStruct{

		User:            config.Section("mysql").Key("user").String(),
		Password:        config.Section("mysql").Key("password").String(),
		Address:         config.Section("mysql").Key("address").String(),
		Port:            config.Section("mysql").Key("port").String(),
		Database:        config.Section("mysql").Key("database").String(),
		Charset:         config.Section("mysql").Key("charset").String(),
		Collation:       config.Section("mysql").Key("collation").String(),
		ConnMaxLifeTime: time.Duration(maxLifeTime) * time.Minute,
		MaxIdleConns:    maxIdleConns,
		MaxOpenConns:    maxOpenConns,
	}
}

func getDbConnection() *sql.DB {
	db, err := sql.Open("mysql", DbConfig.User+":"+DbConfig.Password+"@tcp("+DbConfig.Address+":"+DbConfig.Port+")/"+DbConfig.Database+"?charset="+DbConfig.Charset+"&collation="+DbConfig.Collation)
	if err != nil {
		panic(err)
	}
	//defer db.Close()

	db.SetConnMaxLifetime(DbConfig.ConnMaxLifeTime)
	db.SetMaxIdleConns(DbConfig.MaxIdleConns)
	db.SetMaxOpenConns(DbConfig.MaxOpenConns)
	err = db.Ping()
	if err != nil {
		panic(err)
	}
	return db
}
