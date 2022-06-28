from julia:1.7
copy launch_shuffler.jl launch_shuffler.jl
copy Project.toml Project.toml
RUN julia --project -e 'using Pkg; Pkg.add(url="https://github.com/meggart/DiskArrayShufflers.jl"); Pkg.resolve(); Pkg.precompile()'
ENTRYPOINT ["julia", "--project", "./launch_shuffler.jl"]
#CMD bin/bash