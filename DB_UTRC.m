function [ cid2name, iid2impath, iid2size, iid2setid, oid2cid, oid2diff, oid2iid, oid2bbox, oid2cont ]...
    = DB_UTRC
    global path;
    dbdir = path.db.utrc.root;
    cid2name = dir( dbdir );
    cid2name = { cid2name( 3 : end ).name }';
    numcls = numel( cid2name );
    numval = 500;
    iid2impath = cell( numcls, 1 );
    iid2setid = cell( numcls, 1 );
    oid2cid = cell( numcls, 1 );
    for cid = 1 : numcls,
        clsdir = fullfile( dbdir, cid2name{ cid } );
        iid2impath{ cid } = dir( fullfile( clsdir, '*.JPEG' ) );
        iid2impath{ cid } = fullfile( clsdir, { iid2impath{ cid }.name }' );
        iid2setid{ cid } = ones( size( iid2impath{ cid } ) );
        iid2setid{ cid }( randsample( numel( iid2setid{ cid } ), numval ) ) = 2;
        oid2cid{ cid } = cid * ones( size( iid2impath{ cid } ) );
    end;
    iid2impath = cat( 1, iid2impath{ : } );
    iid2setid = cat( 1, iid2setid{ : } );
    oid2cid = cat( 1, oid2cid{ : } );
    numim = numel( iid2setid );
    iid2size = zeros( 2, numim );
    oid2bbox = zeros( 4, numim );
    fprintf( 'DB: Read ims.\n' );
    parfor iid = 1 : numim,
        [ r, c, ~ ] = size( imread( iid2impath{ iid } ) );
        iid2size( :, iid ) = [ r; c; ];
        oid2bbox( :, iid ) = [ 1; 1; r; c; ];
    end;
    fprintf( 'DB: Done.\n' );
    oid2diff = false( size( iid2setid ) );
    oid2iid = ( 1 : numim )';
    oid2cont = cell( size( iid2setid ) );
end

