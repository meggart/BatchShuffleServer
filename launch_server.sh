#path_to_cube="https://storage.de.cloud.ovh.net/v1/AUTH_84d6da8e37fe4bb5aea18902da8c1170/uc3/FireCube_time1_x1253_y983.zarr"
#path_to_cube="https://s3.bgc-jena.mpg.de:9000/esdl-esdc-v2.1.1/esdc-8d-0.25deg-184x90x90-2.1.1.zarr"
path_to_cube="https://storage.de.cloud.ovh.net/v1/AUTH_84d6da8e37fe4bb5aea18902da8c1170/uc3/UC3SubCube_ts.zarr"
vars_to_include="burned_areas,avg_rh,ignition_points,lst_day,evi"
start_year=2001
end_year=2016
repeats_per_collection=20
batchsize=100
nchunks=10
ip="0.0.0.0"
port=9052
fillvalue="1.0e32"

docker run -p 9052:9052 batchshuffler $path_to_cube -v $vars_to_include -s $start_year -e $end_year -r $repeats_per_collection -b $batchsize -n $nchunks --ip $ip -p $port -f $fillvalue