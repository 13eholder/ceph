#! /bin/bash
pkill ceph-mon
pkill ceph-mgr
pkill ceph-osd
pkill radosgw
# lvremove /dev/ceph--*
umount /var/lib/ceph/osd/*

rm -fr /var/lib/ceph/*
rm -fr /var/run/ceph/*
rm -fr /etc/ceph/*
rm -fr /var/log/ceph/*
rm -fr /var/lib/ceph
rm -fr /var/run/ceph

# 最后根据lsblk的输出移除ceph osd创建的逻辑卷
# 
# sudo umount /dev/mapper/ceph--1da50eec--e7ba--4638--99b8--8e55ce8a0972-osd--block--aaf32775--e79f--4af5--ba94--efdbf15e42f4
# sudo lvremove /dev/mapper/ceph--1da50eec--e7ba--4638--99b8--8e55ce8a0972-osd--block--aaf32775--e79f--4af5--ba94--efdbf15e42f4
