classdef SensorTcpInterface
    %SensorTcpInterface
    properties
        NumMeasurementSamples
    end

    properties
        SensorPort = 8888
    end

    properties (Constant, Access = private)
        CmdStartMeasurement = 'f'
    end

    properties
        SensorIp
        TcpClient
    end

    methods
        function obj = SensorTcpInterface(sensorIp, sensorPort, numSamples)
            if nargin > 1
                obj.SensorPort = sensorPort;
            end
            if nargin > 2
                obj.NumMeasurementSamples = numSamples;
            end
            obj.SensorIp = sensorIp;
            obj.TcpClient = tcpclient(obj.SensorIp, obj.SensorPort);
        end
    end

    methods % low level methods
        function close(obj)
            obj.TcpClient.delete;
        end
        function data = read(obj, siz)
            data = read(obj.TcpClient, siz);
        end
        function write(obj, data)
            write(obj.TcpClient, data);
        end
    end

    methods
        function startMeasurement(obj)
            obj.write(uint8(obj.CmdStartMeasurement));
        end
        
        function data = fetchData(obj)
            data = obj.read(obj.NumMeasurementSamples*2);
            data = typecast(data, 'int16');
        end
        
        function data = fetchSingleSnapshot(obj)
            startMeasurement(obj);
            data = fetchData(obj);
        end
    end
end
