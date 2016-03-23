function cid2map = genHeatMap( im, net, patchSide, stride, scale )
    mapSize = 256;
    [ r0, c0, ~ ] = size( im );
    r = round( r0 * scale );
    c = round( c0 * scale );
    rid2out = extractDenseActivations( im, net, 20, [ r; c; ], patchSide, 0, 2190 * 1643 );
    rid2tlbr = extractDenseRegions( [ r0; c0; ], [ r; c; ], patchSide, stride, 0, 2190 * 1643 );
    numCls = size( rid2out, 1 );
    numRegn = size( rid2out, 2 );
    cid2map = arrayfun( @( x )zeros( mapSize, 'single' ), ( 1 : numCls )', 'UniformOutput', false );
    [ ~, rid2cid ] = max( rid2out, [  ], 1 );
    rid2tlbr_ = round( resizeTlbr( rid2tlbr, max( rid2tlbr( 3 : 4, : ), [  ], 2 ), [ mapSize; mapSize; ] ) );
    cntMap = zeros( mapSize, 'single' );
    for rid = 1 : numRegn,
        r1 = rid2tlbr_( 1, rid ); c1 = rid2tlbr_( 2, rid );
        r2 = rid2tlbr_( 3, rid ); c2 = rid2tlbr_( 4, rid );
        cid = rid2cid( rid );
        cntMap( r1 : r2, c1 : c2 ) = cntMap( r1 : r2, c1 : c2 ) + 1;
        cid2map{ cid }( r1 : r2, c1 : c2 ) = cid2map{ cid }( r1 : r2, c1 : c2 ) + 1;
    end;
    cid2map = cellfun( @( map )imresize( map ./ cntMap, [ r0, c0 ] ), cid2map, 'UniformOutput', false );
end

