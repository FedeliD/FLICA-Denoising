function PhasedSpecs=addphase(specs,AddedPhase);

PhasedSpecs=specs.*(ones(size(specs))*exp(1i*AddedPhase*pi/180));