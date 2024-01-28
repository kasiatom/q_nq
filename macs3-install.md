## MACS3 installation

1) install locally python3.9
```bash
cd
wget https://www.python.org/ftp/python/3.9.0/Python-3.9.0.tgz
tar -zxvf Python-3.9.0.tgz
cd Python-3.9.0/
mkdir ~/.localpython
./configure --prefix=$HOME/.localpython
make
make install
```


2) create and activate virtual environment (with python3.9)
```bash
~/.localpython/bin/python3.9 -m venv venv
source venv/bin/activate
```

3) get MACS3 (fixed version https://github.com/macs3-project/MACS/releases/tag/v3.0.0b3)

```bash
cd
git clone --branch v3.0.0b3  --recurse-submodules git@github.com:taoliu/MACS.git
```

4) install macs3 
```bash
cd MACS/
pip3 install .
```

5) check installation
```bash
macs3 hmmratac --help
```

6) To deactivate virtual environment
```bash
source ~/.bashrc
```
