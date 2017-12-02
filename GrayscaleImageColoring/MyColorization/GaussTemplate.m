function GaussTemplateMatrix = GaussTemplate(sigma)
ImpactRange = round(3*sigma);
GaussTemplateMatrix = zeros(ImpactRange*2 + 1);
for xCounter = 1 : ImpactRange * 2+1
    for yCounter = 1 : ImpactRange * 2+1
        GaussTemplateMatrix(xCounter,yCounter) = 1/(2*pi*sigma^2)*exp(-((xCounter-ImpactRange-1)^2+(yCounter-ImpactRange-1)^2)/(2*sigma^2));
    end
end

