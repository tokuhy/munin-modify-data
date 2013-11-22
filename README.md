munin-modify-data
=================

Description
-----------

--

Munin の監視ノード名を変更した時にデータを引き継ぐには以下のファイルやディレクトリ名も
同時に更新する必要があります。

* /DATADIR/GROUP/HOST-ITEM.rrd
* /DATADIR/state-GROUP-HOST.storable
* /HTMLDIR/GROUP/HOST/

また以下のデータはグラフ閲覧時に作成されるので、ノード名変更時に削除しておいた方がよいです。
* /CGIGRAPHDIR/munin-cgi-graph/GROUP/HOST/

このスクリプトはこれらのファイルとディレクトリの名前を新しいものに更新します。
また、監視項目を削除した場合に必要のないデータを削除することもできます。

Install & Usage
---------------

--

1. ファイルに実行権限を付与
2. `datadir` と `htmldir` と `cgigraphdir` を環境にあわせて設定

あとは引数なしでスクリプトを実行するだけです。メニューからインタラクティブに実行できます。
出力内容に従って実行してください。バッチ処理的な使い方はできません。

Author
------
Fumiaki Tokuyama (tokuhy _at_ gmail.com)

Copyright & License
-------------------
    Copyright 2013 Fumiaki Tokuyama
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
      http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
