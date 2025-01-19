main()

function []=main()
    example1
end

function []=example1()
    kernel_length = 26;
    signal_length = 500;
    filter_length = 5;
    filter = ones(filter_length);
    signal = zeros(signal_length);
    signal(75:85) = 1;
    signal(200:225) = 1;
    signal(280:320) = 1;
    plot(signal, "b")
    hold on;
    for n=filter_length:signal_length-filter_length
        
    end
    pause
end