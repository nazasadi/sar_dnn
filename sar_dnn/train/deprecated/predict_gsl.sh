# the solver used here is a concatanation of the caffe solver and caffe arch file
# a separator is added to indicat the seperation of their contents
# this script first seperate the combined file into two files: solver file and arch
# then the solver and arch files will be configured/filled 
#arch=deploy_3layer_fc_stage_1.prototxt
arch=deploy_3layer_fc.prototxt
cropsize=41
#basedir=/home/lein/sar_dnn/dataset/beaufort_2010_2011/batches_45
basedir=/home/lein/sar_dnn/dataset/gsl2014_hhv_ima/batches_45
meanfile=${basedir}/mean_std.txt
trainsource=${batchdir}/source.txt
weights=${basedir}/model/_iter_2000.caffemodel
imagedir=/home/lein/sar_dnn/dataset/gsl2014_hhv_ima/hhv_land_free
#image25dir=/home/lein/sar_dnn/dataset/beaufort_2010_2011/hhv25
featurename=fc5
predictdir=${basedir}/predict_base
mkdir -p ${predictdir}
archfill=.fill_${arch}
cp ${arch} ${archfill}

fancyDelim=$(printf '\001')
sed -i "s${fancyDelim}\$train_mean${fancyDelim}${meanfile}${fancyDelim}g" $archfill
sed -i "s${fancyDelim}\$crop_size${fancyDelim}${cropsize}${fancyDelim}g" $archfill

for f in ${imagedir}/*-HV-8by8-mat.tif
do
scene=${f##*/}
scene=${scene:0:15}
#scene=20140210_103911
echo $scene
hh=${scene}-HH-8by8-mat.tif
hv=${scene}-HV-8by8-mat.tif
#image=${imagedir}/${hh},${imagedir}/${hv},${image25dir}/${hh},${image25dir}/${hv}
image=${imagedir}/${hh},${imagedir}/${hv}
predict=${predictdir}/${scene}_2000.tif
if [ -f ${predict} ]
then
  continue
fi
/home/lein/dev/caffe/build/tools/caffe_predict \
    --model=${archfill} \
    --weights=${weights} \
    --image=${image} \
    --meanfile=${meanfile} \
    --featurename=${featurename} \
    --predict=${predict}
done

