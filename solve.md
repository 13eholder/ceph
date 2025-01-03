## Tips
使用 sudo journalctl -u ceph-mon@s52 来查看 ceph-mon的输出日志,根据日志判断出错位置

### 问题
报错信息: Dec 31 19:40:55 s52.pdsl.local ceph-mon[216453]: unable to look up user 'ceph'
问题: 没有ceph用户
解决方法:
<!-- sudo useradd -d /var/lib/ceph -s /bin/false -r -m -U ceph-->
<!-- sudo useradd -s /bin/false -r -m -U ceph -->
<!-- sudo useradd  -m -U ceph -->
sudo useradd ceph
id ceph
sudo passwd ceph
sudo visudo
<!-- 添加信息到 /etc/sudoers -->
ceph ALL=(root) NOPASSWD:ALL

## ceph-deploy
cd /etc/ceph
sudo mkdir -p /var/lib/ceph/{osd,mgr} /var/run/ceph /etc/ceph

sudo chown -R ceph:ceph /var/lib/ceph
sudo chown -R ceph:ceph /var/run/ceph
sudo chown -R ceph:ceph /etc/ceph
sudo chmod -R 777 /var/run/ceph /var/lib/ceph /etc/ceph  

ceph-deploy new s52

修改/etc/ceph.conf⽂件，设置副本数，这⾥是单机设置为1
osd pool default size = 1
osd pool default min size = 1
public_network = 192.168.1.0/24

ceph-deploy --overwrite-conf mon create-initial
<!-- sudo chmod 777 ./ceph.client.admin.keyring ./ceph.mon.keyring ./ceph.bootstrap-osd.keyring  ./ceph.bootstrap-rgw.keyring ./ceph.bootstrap-mds.keyring ./ceph.bootstrap-mgr.keyring -->

ceph-deploy --overwrite-conf admin s52
<!-- sudo chmod 777 /etc/ceph/ceph.client.admin.keyring  -->

ceph-deploy --overwrite-conf mgr create s52
<!-- sudo chmod 777 /var/lib/ceph/bootstrap-mgr/ceph.keyring -->

ceph-deploy getherkeys s52


<!-- sudo chown ceph:ceph /etc/ceph/ceph.client.admin.keyring -->
<!-- sudo chmod 666 /etc/ceph/ceph.client.admin.keyring -->


### 创建虚拟盘[Deprecated]
<!-- sudo dd if=/dev/zero of=/var/lib/ceph/osd/osd1.img bs=1G count=300
sudo dd if=/dev/zero of=/var/lib/ceph/osd/osd2.img bs=1G count=300
sudo dd if=/dev/zero of=/var/lib/ceph/osd/osd3.img bs=1G count=300

sudo losetup /dev/loop1 /var/lib/ceph/osd/osd1.img
sudo losetup /dev/loop2 /var/lib/ceph/osd/osd2.img
sudo losetup /dev/loop3 /var/lib/ceph/osd/osd3.img

sudo losetup -f /var/lib/ceph/osd/osd1.img
sudo losetup -f /var/lib/ceph/osd/osd2.img
sudo losetup -f /var/lib/ceph/osd/osd3.img

losetup -a 查看

/dev/loop0: []: (/var/lib/ceph/osd/osd1.img)
/dev/loop1: []: (/var/lib/ceph/osd/osd2.img)
/dev/loop4: []: (/var/lib/ceph/osd/osd3.img)
/dev/loop2: []: (/var/lib/snapd/snaps/snapd_23258.snap)
/dev/loop7: []: (/var/lib/snapd/snaps/core20_2434.snap)
/dev/loop5: []: (/var/lib/snapd/snaps/core20_1828.snap)
/dev/loop3: []: (/var/lib/snapd/snaps/snapd_21759.snap)

sudo mkfs.xfs /dev/loop0
sudo mkfs.xfs /dev/loop1
sudo mkfs.xfs /dev/loop4

挂载
sudo mkdir -p /var/lib/ceph/osd/osd1
sudo mkdir -p /var/lib/ceph/osd/osd2
sudo mkdir -p /var/lib/ceph/osd/osd3

sudo mount /dev/loop0 /var/lib/ceph/osd/osd1
sudo mount /dev/loop1 /var/lib/ceph/osd/osd2
sudo mount /dev/loop4 /var/lib/ceph/osd/osd3

ceph-deploy --overwrite-conf osd create --data /dev/nvme0n1p1 --bluestore `hostname`

sudo umount /var/lib/ceph/osd/osd1
sudo umount /var/lib/ceph/osd/osd2
sudo umount /var/lib/ceph/osd/osd3
删除回环设备：

sudo losetup -d /dev/loop0
sudo losetup -d /dev/loop1
sudo losetup -d /dev/loop4
删除虚拟磁盘文件：

sudo rm /var/lib/ceph/osd/osd1.img
sudo rm /var/lib/ceph/osd/osd2.img
sudo rm /var/lib/ceph/osd/osd3.img -->

### 创建分区
nvme2n1盘有1.8T内存，并且没有被挂载,在此基础上划分分区并作为ceph osd
sudo parted /dev/nvme2n1

使用分区
nvme2n1                   259:0    0   1.8T  0 disk 
├─nvme2n1p1               259:9    0 279.4G  0 part 
├─nvme2n1p2               259:10   0 279.4G  0 part 
├─nvme2n1p3               259:11   0 279.4G  0 part 
└─nvme2n1p4               259:12   0     1T  0 part 

 ceph-deploy --overwrite-conf osd create --data /dev/nvme2n1p1 --bluestore s52 
 ceph-deploy --overwrite-conf osd create --data /dev/nvme2n1p2 --bluestore s52 
 ceph-deploy --overwrite-conf osd create --data /dev/nvme2n1p3 --bluestore s52 

遇到报错 RuntimeError: Device /dev/nvme2n1p1 has a filesystem.
sudo ceph-volume lvm zap /dev/nvme2n1p1
sudo ceph-volume lvm zap /dev/nvme2n1p2
sudo ceph-volume lvm zap /dev/nvme2n1p3


#### 未解决的问题,创建OSD报错
ceph-deploy --overwrite-conf osd create --data /dev/nvme2n1p1 --bluestore s52  
[ceph_deploy.conf][DEBUG ] found configuration file at: /home/ceph/.cephdeploy.conf
[ceph_deploy.cli][INFO  ] Invoked (2.0.1): /usr/bin/ceph-deploy --overwrite-conf osd create --data /dev/nvme2n1p1 --bluestore s52
[ceph_deploy.cli][INFO  ] ceph-deploy options:
[ceph_deploy.cli][INFO  ]  verbose                       : False
[ceph_deploy.cli][INFO  ]  quiet                         : False
[ceph_deploy.cli][INFO  ]  username                      : None
[ceph_deploy.cli][INFO  ]  overwrite_conf                : True
[ceph_deploy.cli][INFO  ]  ceph_conf                     : None
[ceph_deploy.cli][INFO  ]  cluster                       : ceph
[ceph_deploy.cli][INFO  ]  subcommand                    : create
[ceph_deploy.cli][INFO  ]  cd_conf                       : <ceph_deploy.conf.cephdeploy.Conf object at 0x7f54f5e74e20>
[ceph_deploy.cli][INFO  ]  default_release               : False
[ceph_deploy.cli][INFO  ]  func                          : <function osd at 0x7f54f5e8d160>
[ceph_deploy.cli][INFO  ]  data                          : /dev/nvme2n1p1
[ceph_deploy.cli][INFO  ]  journal                       : None
[ceph_deploy.cli][INFO  ]  zap_disk                      : False
[ceph_deploy.cli][INFO  ]  fs_type                       : xfs
[ceph_deploy.cli][INFO  ]  dmcrypt                       : False
[ceph_deploy.cli][INFO  ]  dmcrypt_key_dir               : /etc/ceph/dmcrypt-keys
[ceph_deploy.cli][INFO  ]  filestore                     : None
[ceph_deploy.cli][INFO  ]  bluestore                     : True
[ceph_deploy.cli][INFO  ]  block_db                      : None
[ceph_deploy.cli][INFO  ]  block_wal                     : None
[ceph_deploy.cli][INFO  ]  host                          : s52
[ceph_deploy.cli][INFO  ]  debug                         : False
[ceph_deploy.osd][DEBUG ] Creating OSD on cluster ceph with data device /dev/nvme2n1p1
[s52][DEBUG ] connection detected need for sudo
[s52][DEBUG ] connected to host: s52 
[ceph_deploy.osd][INFO  ] Distro info: ubuntu 20.04 focal
[ceph_deploy.osd][DEBUG ] Deploying osd to s52
[s52][INFO  ] Running command: sudo /usr/sbin/ceph-volume --cluster ceph lvm create --bluestore --data /dev/nvme2n1p1
[s52][WARNIN] Running command: /usr/bin/ceph-authtool --gen-print-key
[s52][WARNIN] Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring -i - osd new d09c7704-b31f-4318-a395-fd6eb2708901
[s52][WARNIN] Running command: vgcreate --force --yes ceph-845ca605-3b23-47d8-a114-f0e185d97701 /dev/nvme2n1p1
[s52][WARNIN]  stdout: Physical volume "/dev/nvme2n1p1" successfully created.
[s52][WARNIN]  stdout: Volume group "ceph-845ca605-3b23-47d8-a114-f0e185d97701" successfully created
[s52][WARNIN] Running command: lvcreate --yes -l 71525 -n osd-block-d09c7704-b31f-4318-a395-fd6eb2708901 ceph-845ca605-3b23-47d8-a114-f0e185d97701
[s52][WARNIN]  stdout: Logical volume "osd-block-d09c7704-b31f-4318-a395-fd6eb2708901" created.
[s52][WARNIN] Running command: /usr/bin/ceph-authtool --gen-print-key
[s52][WARNIN] Running command: /usr/bin/mount -t tmpfs tmpfs /var/lib/ceph/osd/ceph-1
[s52][WARNIN] --> Executable selinuxenabled not in PATH: /usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin/usr/local/bin:/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/sbin
[s52][WARNIN] Running command: /usr/bin/chown -h ceph:ceph /dev/ceph-845ca605-3b23-47d8-a114-f0e185d97701/osd-block-d09c7704-b31f-4318-a395-fd6eb2708901
[s52][WARNIN] Running command: /usr/bin/chown -R ceph:ceph /dev/dm-1
[s52][WARNIN] Running command: /usr/bin/ln -s /dev/ceph-845ca605-3b23-47d8-a114-f0e185d97701/osd-block-d09c7704-b31f-4318-a395-fd6eb2708901 /var/lib/ceph/osd/ceph-1/block
[s52][WARNIN] Running command: /usr/bin/ceph --cluster ceph --name client.bootstrap-osd --keyring /var/lib/ceph/bootstrap-osd/ceph.keyring mon getmap -o /var/lib/ceph/osd/ceph-1/activate.monmap
[s52][WARNIN]  stderr: 2025-01-02T20:02:42.406+0800 7efd349ea700 -1 auth: unable to find a keyring on `/etc/ceph/ceph.client.bootstrap-osd.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin`: (2) No such file or directory
[s52][WARNIN] 2025-01-02T20:02:42.406+0800 7efd349ea700 -1 AuthRegistry(0x7efd300610f0) no keyring found at /etc/ceph/ceph.client.bootstrap-osd.keyring,/etc/ceph/ceph.keyring,/etc/ceph/keyring,/etc/ceph/keyring.bin, disabling cephx
[s52][WARNIN]  stderr: got monmap epoch 1
[s52][WARNIN] --> Creating keyring file for osd.1
[s52][WARNIN] Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-1/keyring
[s52][WARNIN] Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-1/
[s52][WARNIN] Running command: /usr/bin/ceph-osd --cluster ceph --osd-objectstore bluestore --mkfs -i 1 --monmap /var/lib/ceph/osd/ceph-1/activate.monmap --keyfile - --osd-data /var/lib/ceph/osd/ceph-1/ --osd-uuid d09c7704-b31f-4318-a395-fd6eb2708901 --setuser ceph --setgroup ceph
[s52][WARNIN]  stderr: 2025-01-02T20:02:42.630+0800 7f0e9e3853c0 -1 bluestore(/var/lib/ceph/osd/ceph-1/) _read_fsid unparsable uuid
[s52][WARNIN]  stderr: 2025-01-02T20:02:43.445+0800 7f0e9e3853c0 -1 bluestore::NCB::__restore_allocator::Failed open_for_read with error-code -2
[s52][WARNIN]  stderr: 2025-01-02T20:02:44.233+0800 7f0e9e3853c0 -1 bluestore::NCB::__restore_allocator::Failed open_for_read with error-code -2
[s52][WARNIN] --> ceph-volume lvm prepare successful for: /dev/nvme2n1p1
[s52][WARNIN] Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-1
[s52][WARNIN] Running command: /usr/bin/ceph-bluestore-tool --cluster=ceph prime-osd-dir --dev /dev/ceph-845ca605-3b23-47d8-a114-f0e185d97701/osd-block-d09c7704-b31f-4318-a395-fd6eb2708901 --path /var/lib/ceph/osd/ceph-1 --no-mon-config
[s52][WARNIN] Running command: /usr/bin/ln -snf /dev/ceph-845ca605-3b23-47d8-a114-f0e185d97701/osd-block-d09c7704-b31f-4318-a395-fd6eb2708901 /var/lib/ceph/osd/ceph-1/block
[s52][WARNIN] Running command: /usr/bin/chown -h ceph:ceph /var/lib/ceph/osd/ceph-1/block
[s52][WARNIN] Running command: /usr/bin/chown -R ceph:ceph /dev/dm-1
[s52][WARNIN] Running command: /usr/bin/chown -R ceph:ceph /var/lib/ceph/osd/ceph-1
[s52][WARNIN] Running command: /usr/bin/systemctl enable ceph-volume@lvm-1-d09c7704-b31f-4318-a395-fd6eb2708901
[s52][WARNIN]  stderr: Created symlink /etc/systemd/system/multi-user.target.wants/ceph-volume@lvm-1-d09c7704-b31f-4318-a395-fd6eb2708901.service → /lib/systemd/system/ceph-volume@.service.
[s52][WARNIN] Running command: /usr/bin/systemctl enable --runtime ceph-osd@1
[s52][WARNIN]  stderr: Created symlink /run/systemd/system/ceph-osd.target.wants/ceph-osd@1.service → /lib/systemd/system/ceph-osd@.service.
[s52][WARNIN] Running command: /usr/bin/systemctl start ceph-osd@1
[s52][WARNIN] --> ceph-volume lvm activate successful for osd ID: 1
[s52][WARNIN] --> ceph-volume lvm create successful for: /dev/nvme2n1p1
[s52][INFO  ] checking OSD status...
[s52][INFO  ] Running command: sudo /bin/ceph --cluster=ceph osd stat --format=json
[s52][WARNIN] there are 2 OSDs down
[ceph_deploy.osd][DEBUG ] Host s52 is now ready for osd use.


## 手动部署

### 创建  /etc/ceph/ceph.conf

[global]
fsid = 525524fd-a25e-45cb-8ada-bb33f8e08966
mon_initial_members = s52
mon_host = 192.168.1.52
auth_cluster_required = cephx
auth_service_required = cephx
auth_client_required = cephx
osd pool default size = 1
osd pool default min size = 1
public_network = 192.168.1.0/24

sudo chmod 666 /etc/ceph/ceph.conf

mkdir /etc/ceph
sudo mkdir -p /var/lib/ceph/bootstrap-osd
sudo chmod 777 /var/lib/ceph/bootstrap-osd
<!-- sudo chown -R ceph:ceph /var/lib/ceph/bootstrap-osd -->

### 创建密钥
sudo ceph-authtool --create-keyring /etc/ceph/ceph.mon.keyring --gen-key -n mon. --cap mon 'allow *'
sudo ceph-authtool --create-keyring /etc/ceph/ceph.client.admin.keyring --gen-key -n client.admin --cap mon 'allow *' --cap osd 'allow *' --cap mds 'allow *' --cap mgr 'allow *'
sudo chmod 666 /etc/ceph/ceph.mon.keyring /etc/ceph/ceph.client.admin.keyring   
sudo ceph-authtool --create-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring --gen-key -n client.bootstrap-osd --cap mon 'profile bootstrap-osd' --cap mgr 'allow r'
sudo chmod 666 /var/lib/ceph/bootstrap-osd/ceph.keyring 
sudo ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /etc/ceph/ceph.client.admin.keyring
sudo ceph-authtool /etc/ceph/ceph.mon.keyring --import-keyring /var/lib/ceph/bootstrap-osd/ceph.keyring
<!-- sudo monmaptool --create --add localhost 127.0.0.1 --fsid  07422030-78fc-47bb-9154-c9da52eff6b6 /etc/ceph/monmap -->
sudo monmaptool --create --add s52 192.168.1.52 --fsid 525524fd-a25e-45cb-8ada-bb33f8e08966 /etc/ceph/monmap

### 开启mon
sudo mkdir -p /var/run/ceph
sudo chmod 666 /var/run/ceph
sudo mkdir -p /var/lib/ceph/mon/ceph-s52
sudo chown -R ceph:ceph /var/lib/ceph/mon/
sudo chmod -R 777 /var/lib/ceph/mon/ceph-s52
<!-- sudo chown -R ceph:ceph /var/lib/ceph/mon/ceph-s52 -->
sudo ceph-mon --cluster ceph --mkfs -i s52 --monmap /etc/ceph/monmap --keyring /etc/ceph/ceph.mon.keyring
sudo systemctl enable ceph-mon@s52
sudo systemctl start ceph-mon@s52
sudo systemctl status ceph-mon@s52
### 开启mgr
sudo mkdir -p /var/lib/ceph/mgr/ceph-s52/
sudo chmod 777 /var/lib/ceph/mgr/ceph-s52/
sudo chown -R ceph:ceph /var/lib/ceph/mgr/
<!-- sudo chown -R ceph:ceph /var/lib/ceph/mgr/ceph-s52/ -->
sudo ceph auth get-or-create mgr.s52 mon 'allow profile mgr' osd 'allow *' mds 'allow *' -o /var/lib/ceph/mgr/ceph-s52/keyring
sudo ceph-mgr -i s52--cluster ceph

### 开启osd
sudo apt install pkgconf.x86_64  

sudo ceph-volume lvm create --data /dev/nvme2n1p1  
uuidgen  
`uuid`
sudo ceph osd create `uuid` 0  
sudo mkdir -p /var/lib/ceph/osd/ceph-0/  

sudo ceph auth get-or-create osd.0 osd 'allow *' mon 'allow rwx' mgr 'allow profile osd' -o /var/lib/ceph/osd/ceph-0/keyring  
 

sudo journalctl -u ceph-mon@s52  