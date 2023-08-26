#!/system/bin/sh
#
# Copyright 2023 shadow3aaa@gitbub.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

SKIPUNZIP=0
dir=/sdcard/Android/fas-rs
conf=/sdcard/Android/fas-rs/games.toml
old_conf=/sdcard/Android/fas-rs/games.txt

# permission
chmod a+x $MODPATH/fas-rs

# detect conflicting kernel modules
if lsmod | grep -q "ged_novsync"; then
	ui_print "Conflicting kernel module"
	abort
fi

if [ -f $old_conf ]; then
	# rename as .toml
	mv $old_conf $conf
fi

if [ -f $conf ]; then
	# merge local std
	$MODPATH/fas-rs merge $conf $MODPATH/games.toml
else
	# creat new config
	mkdir -p /sdcard/Android/fas-rs
	cp $MODPATH/games.toml $conf
fi

killall fas-rs

# test support
if $MODPATH/fas-rs "test"; then
	ui_print "Supported"
else
	ui_print "Unsupported"
	source $MODPATH/uninstall.sh
	abort
fi

# hot re-run
nohup env FAS_LOG=info $MODPATH/fas-rs >$dir/fas_log.txt 2>&1 &

# remove std config
rm $MODPATH/games.toml

# vtools support
sh $MODPATH/vtools/init_vtools.sh $(realpath $MODPATH/module.prop)