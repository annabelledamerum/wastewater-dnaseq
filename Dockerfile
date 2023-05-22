FROM nfcore/base:1.9

COPY environment.yml /

RUN conda env create -f /environment.yml && conda clean -a

COPY assets/mqc_plugins /opt/mqc_plugins

SHELL ["/bin/bash", "--login", "-c"]

RUN conda activate zymobiomics_shotgun && cd /opt/mqc_plugins && python setup.py install

ENV PATH "/opt/conda/envs/zymobiomics_shotgun/bin:$PATH"

RUN echo "export PATH=/opt/conda/envs/zymobiomics_shotgun/bin:$PATH" >> /root/.bashrc
