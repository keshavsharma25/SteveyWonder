import { useScaffoldContractRead } from "~~/hooks/scaffold-eth";

export const useRenderTokenSVGWithoutBg = (tokenId: bigint | undefined) => {
  const { data: svgSrc } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "generateSVGwithoutBackground",
    args: [tokenId],
    watch: true,
    cacheTime: 30_000,
    staleTime: 1000,
  });

  if (!svgSrc) {
    return { base64Image: undefined };
  }

  const base64Image = Buffer.from(svgSrc, "utf8").toString("base64");

  return { base64Image };
};
