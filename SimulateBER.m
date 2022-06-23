% Generate input sequence
lfsr_inital_state = [1, 1, 1, 1, 1, 1, 1, 1, 1, 1];
feedback_taps = [10, 7]; %Chose optimal taps from wikipedia for M=10, yields a ~50% distribution of 0s and 1s
lfsr_output_size = 1000; % Specify size of signal
input_stream = LFSRv3(lfsr_inital_state,feedback_taps,lfsr_output_size);
input_stream = (input_stream*2)-1; %scale for antipodal signalling

error_counter = 0; % Variable for counting number of errors
output_stream = zeros(1,lfsr_output_size);
EbNo_dB = 0:0.01:30; % Initialize Eb/No in dB
ber = zeros(1, length(EbNo_dB));

num_runs = 100; % Number of times the ber for each eb/no is calculated

%For each value of Eb/No, create a noise vector the size of the input
%sequence and add to it. Then, go through the contaminated sequence and
%apply the optimum decision threshold. Compare each value after deicison
%with the original input, and increment the error counter if they don't
%match
for j = 1:length(EbNo_dB)
    for k = 1:num_runs
        noise = sqrt(0.5/(10^(EbNo_dB(j)/10)))*randn(1,lfsr_output_size); %scale noise with unit variance by calculated variance
        contaminated_stream = input_stream+noise;
    
        for i=1:1:length(contaminated_stream)
            % Apply optimum decision threshold
            if(contaminated_stream(i) > 0)
                output_stream(i) = 1;
            elseif(contaminated_stream(i) <= 0)
                output_stream(i) = -1;
            end
            %Check output bit against input, and increment error counter if
            %they are different
            if(output_stream(i) ~= input_stream(i))
                error_counter = error_counter + 1;
            end
        end
        ber(j) = ber(j) + error_counter/lfsr_output_size; % Percentage of time bits are in error
        error_counter = 0;
    end
end

ber = ber/num_runs; %take the average over all runs
semilogy(EbNo_dB, ber);
xlabel("Eb/No (dB)");
ylabel("BER (dB)");

hold on

semilogy(EbNo_dB, qfunc(sqrt(2*10.^(EbNo_dB/10))), LineWidth=3);
ylim([10^-3, 10^-1])

legend("Simulated BER", "Theoretical BER")