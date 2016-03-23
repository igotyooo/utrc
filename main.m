%% SET ENVIRONMENT.
global path;
path.lib.matConvNet = '/your/matconvnet/beta12/root/'; % You must install "beta 12"!
path.dstDir = './dataout';
path.db.utrc.name = 'UTRC';
path.db.utrc.funh = @DB_UTRC;
path.db.utrc.root = './datain/db/train';
path.db.utrc_test.root = './datain/db/test';
path.net.vgg_m.name = 'VGGM';
path.net.vgg_m.path = './datain/net/imagenet-vgg-m.mat';

%% SET PARAMETERS.
setting.gpus = 1;
setting.db = path.db.utrc;
setting.io.net.pretrainedNetName = path.net.vgg_m.name;
setting.io.net.suppressPretrainedLayerLearnRate = 0.1;
setting.io.general.shuffleSequance = true; 
setting.io.general.batchSize = 128;
setting.net.normalizeImage = 'NONE';
setting.net.weightDecay = 0.0005;
setting.net.momentum = 0.9;
setting.net.modelType = 'dropout';
setting.net.learningRate = [ 0.01 * ones( 1, 3 ), 0.001 * ones( 1, 1 ) ];
setting.test.scale = ( 219 / 64 ) / 2;

%% TRAINING NETWOK.
run( fullfile( path.lib.matConvNet, 'matlab/vl_setupnn.m' ) );
addpath( './net', './utils' ); 
reset( gpuDevice( setting.gpus ) );
db = Db( setting.db, path.dstDir );
db.genDb;
io = InOutCls( db, setting.io.net, setting.io.general );
io.init;
net = Net( io, setting.net );
net.init;
net.train( setting.gpus );
net.fetchBestNet;
[ net, netName ] = net.provdNet;
net.name = netName;
net.normalization.averageImage = io.rgbMean;

%% TEST.
clearvars -except db io net path setting; 
iid2path = dir( fullfile( path.db.utrc_test.root, '*.png' ) );
iid2path = fullfile( path.db.utrc_test.root, { iid2path.name }' );
iid = 1;
im = imread( iid2path{ iid } );
cid2map = genHeatMap( im, net, io.patchSide, io.stride, setting.test.scale );
cid2map = cellfun( @( map )repmat( uint8( 255 * map ), [ 1, 1, 3 ] ), cid2map, 'UniformOutput', false );
figure; imshow( imresize( cat( 2, im, cid2map{ : } ), 1 / 2 ) );