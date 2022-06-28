#/usr/bin/bash julia
using DiskArrayShufflers
using YAXArrays, EarthDataLab
using DiskArrays, Zarr
using Logging
using ArgParse

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table! s begin
        "--vars_to_include", "-v"
            help = "comma-seperated list of variable names to be sampled"
            arg_type = String
            default = ""
        "path"
            help = "Path or URL to Data Cube"
            arg_type = String
            required=true
        "--start_year", "-s"
            help = "Start year"
            default = 1900
            arg_type = Int
        "--end_year", "-e"
            help = "End year"
            default = 2100
            arg_type = Int
        "--repeats_per_collection", "-r"
            help = "...."
            default = 10
            arg_type = Int
        "--batchsize", "-b"
            help = "Number of time series returned per batch"
            default = 100
            arg_type = Int            
        "--nchunks", "-n"
            help = "Number of chunks kept in memory concurrently"
            default = 10
            arg_type = Int  
        "--ip", "-i"
            help = "Ip address to serve from"
            arg_type = String 
            required = true
        "--port", "-p"
            help = "Port to use for server"
            arg_type = Int
            required=true
    end

    return parse_args(s)
end

parsed_args = parse_commandline()

path_to_cube = parsed_args["path"]
vars_to_include=string.(split(parsed_args["vars_to_include"],','))
start_year=parsed_args["start_year"]
end_year=parsed_args["end_year"]
repeats_per_collection=parsed_args["repeats_per_collection"]
batchsize=parsed_args["batchsize"]
nchunks=parsed_args["nchunks"]


debuglogger = ConsoleLogger(stderr, Logging.Debug)
global_logger(debuglogger)

#g = zopen("/scratch/DataCube/v2.0.0/esdc-8d-0.25deg-184x90x90-2.0.0.zarr/", fill_as_missing=false)
#g = zopen("/Net/Groups/BGI/scratch/DataCube/esdc-8d-0.25deg-184x90x90-2.0.0.zarr/", fill_as_missing=false)

g = zopen(path_to_cube, fill_as_missing=false)

c = Cube(YAXArrays.open_dataset(g))

c = c[time=start_year:end_year]

c = isempty(vars_to_include) ? c : c[var=vars_to_include]

itime = YAXArrays.Cubes.findAxis("Time",c)
ivar = YAXArrays.Cubes.findAxis("Var",c)

sharear = c.data
ntime = size(sharear,itime)
nvar = size(sharear,ivar)
cs = DiskArrays.eachchunk(sharear);

newchunks = Base.setindex(cs.chunks,DiskArrays.RegularChunks(ntime,0,ntime),itime)
newchunks = Base.setindex(newchunks,DiskArrays.RegularChunks(nvar,0,nvar),ivar)

sampler = FullSliceSampler(itime,ivar,batchespercoll=repeats_per_collection,batchsize = batchsize, nchunks = nchunks)

shuffler = DiskArrayShuffler(sharear, sampler; chunks = DiskArrays.GridChunks(newchunks...));


store = DiskArrayShuffleStore(shuffler);


import HTTP
using Sockets
HTTP.serve(store,"",parse(IPAddr,parsed_args["ip"]),parsed_args["port"])