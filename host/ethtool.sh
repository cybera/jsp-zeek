#!/bin/bash
for int in eno1 enp101s0f0np0 enp101s0f1np1 enp179s0f0np0 enp179s0f1np1;
do
        for i in rx tx sg tso ufo gso gro lro; do ethtool -K $int $i off; done
done
