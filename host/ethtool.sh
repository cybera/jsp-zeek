#!/bin/bash
for int in eno1 enp101s0f0np0 enp101s0f1np1 enp179s0f0np0 enp179s0f1np1;
do
        for i in rx tx sg tso ufo gso gro lro; do ethtool -K $int $i off; done

        # Set max RX ring buffer size
        ethtool -g $int |grep RX |head -1 |awk '{ print $2 }' | xargs /sbin/ethtool -G $int rx
done
