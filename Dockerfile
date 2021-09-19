# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.194.0/containers/ubuntu/.devcontainer/base.Dockerfile

# [Choice] Ubuntu version: bionic, focal
ARG VARIANT="focal"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-${VARIANT}

# [Optional] Uncomment this section to install additional OS packages.
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive
RUN apt-get -y install build-essential libboost1.67-all-dev && apt-get clean
RUN apt-get -y install --no-install-recommends \
    python curl \
    python3-pip autoconf automake flex bison ccache \ 
    libgoogle-perftools-dev numactl perl-doc \
    libfl2 libfl-dev zlibc zlib1g zlib1g-dev \ 
    build-essential clang libreadline-dev \
    gawk tcl-dev libffi-dev git mercurial graphviz \
    xdot pkg-config libftdi-dev gperf \
    libgmp-dev autotools-dev libmpc-dev libmpfr-dev \
    texinfo libtool patchutils bc libexpat-dev \
    cmake && apt-get clean

RUN pip3 install --upgrade fusesoc && pip3 install --upgrade pytest

# Install Yosys
RUN git clone https://github.com/YosysHQ/yosys.git yosys && \
    cd yosys && \
    make -j$(nproc) && \
    make install && \
    cd .. && rm -rf yosys 

# Install Symbiyosys
RUN git clone https://github.com/YosysHQ/SymbiYosys.git SymbiYosys && \
    cd SymbiYosys && \
    make install && \
    cd .. && rm -rf SymbiYosys 

# begin Install Formal Prover Dependencies
RUN git clone https://github.com/SRI-CSL/yices2.git yices2 && \
    cd yices2 && \
    autoconf && \
    ./configure && \
    make -j$(nproc) && \
    make install && \
    cd .. && rm -rf yices2 

RUN git clone https://github.com/boolector/boolector && \
    cd boolector && \
    ./contrib/setup-btor2tools.sh && \
    ./contrib/setup-lingeling.sh && \
    ./configure.sh && \
    make -C build -j$(nproc) && \
    cp build/bin/boolector /usr/local/bin/ && \
    cp build/bin/btor* /usr/local/bin/ && \
    cp deps/btor2tools/bin/btorsim /usr/local/bin/ && \
    cd .. && rm -rf boolector 

RUN git clone https://bitbucket.org/arieg/extavy.git && \
   cd extavy && \
   git submodule update --init && \
   mkdir build; cd build && \
   cmake -DCMAKE_BUILD_TYPE=Release .. && \
   make -j$(nproc) && \
   cp avy/src/avy /usr/local/bin/ && \
   cp avy/src/avybmc /usr/local/bin/ && \
   cd ../.. && rm -rf extavy     

RUN git clone https://github.com/Z3Prover/z3.git z3 && \
   cd z3 && \ 
   python scripts/mk_make.py && \ 
   cd build && \ 
   make -j$(nproc) && \ 
   make install && \
   cd ../.. && rm -rf z3 

# end Install Formal Prover Dependencies

RUN curl -sSL https://get.haskellstack.org/ | sh && \
    git clone https://github.com/zachjs/sv2v.git && \
    cd sv2v && \
    make && \
    cp bin/sv2v /usr/local/bin && \
    cd .. && rm -rf sv2v 

# Install verilator
RUN apt-get -y install verilator && apt-get clean

# Install riscv gnu toolchain
RUN curl -L https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2021.09.16/riscv32-elf-ubuntu-20.04-nightly-2021.09.16-nightly.tar.gz -O && \
    tar -xvf riscv32*.tar.gz && \
    rm riscv32*.tar.gz 
    
ENV PATH="/riscv/bin:${PATH}"


