# MemoApp

これは、フィヨルドブートキャンプの研修課題です。



### データベースの準備
```
CREATE TABLE Memos
(id serial,
title VARCHAR(100) NOT NULL,
content VARCHAR(1000) ,
PRIMARY KEY (id));
```

### アプリケーションの実行方法
```
$ bundle exec ruby main.rb
```