            o=0;
            l=0;

            for (int i = 0; i < graph.num_auxiliary_1; i++) begin
                graph.auxiliary_1[l][(M_AXI4_FE_DATA_W*o)+:M_AXI4_FE_DATA_W] = {M_AXI4_FE_DATA_W{1'b1}};
                if(i == 0)begin
                    graph.auxiliary_1[l][(M_AXI4_FE_DATA_W*o)+:M_AXI4_FE_DATA_W] = 0;
                end
                o++;
                if (o%(M_AXI4_BE_DATA_W/M_AXI4_FE_DATA_W) == 0) begin
                    l++;
                    o=0;
                end
            end

            for (int i = graph.num_auxiliary_1; i <  graph.num_auxiliary_1*2 ; i++) begin
                graph.auxiliary_1[l][(M_AXI4_FE_DATA_W*o)+:M_AXI4_FE_DATA_W] = 0;

                if(i == graph.num_auxiliary_1 )begin
                    graph.auxiliary_1[l][(M_AXI4_FE_DATA_W*o)+:M_AXI4_FE_DATA_W] = 1;
                end
                o++;
                if (o%(M_AXI4_BE_DATA_W/M_AXI4_FE_DATA_W) == 0) begin
                    l++;
                    o=0;
                end
            end

            o=0;
            l=0;

            for (int i = 0; i <  graph.num_auxiliary_2 ; i++) begin
                graph.auxiliary_2[l][(M_AXI4_FE_DATA_W*o)+:M_AXI4_FE_DATA_W] = {M_AXI4_FE_DATA_W{1'b1}};
                o++;
                if (o%(M_AXI4_BE_DATA_W/M_AXI4_FE_DATA_W) == 0) begin
                    l++;
                    o=0;
                end
            end

            for (int i = graph.num_auxiliary_2; i < graph.num_auxiliary_2*2; i++) begin
                graph.auxiliary_2[l][(M_AXI4_FE_DATA_W*o)+:M_AXI4_FE_DATA_W] = 0;
                o++;
                if (o%(M_AXI4_BE_DATA_W/M_AXI4_FE_DATA_W) == 0) begin
                    l++;
                    o=0;
                end
            end