#path_to_cube="https://storage.de.cloud.ovh.net/v1/AUTH_84d6da8e37fe4bb5aea18902da8c1170/uc3/FireCube_time1_x1253_y983.zarr"
path_to_cube="https://s3.bgc-jena.mpg.de:9000/esdl-esdc-v2.1.1/esdc-8d-0.25deg-184x90x90-2.1.1.zarr"
vars_to_include="gross_primary,leaf_area,air_temperature"
start_year=2001
end_year=2016
repeats_per_collection=10
batchsize=100
nchunks=10
ip="141.5.17.118"
port=9052

julia --project test_shuffler.jl $path_to_cube -v $vars_to_include -s $start_year -e $end_year -r $repeats_per_collection -b $batchsize -n $nchunks --ip $ip -p $port