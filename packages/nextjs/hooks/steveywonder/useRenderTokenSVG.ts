import { useScaffoldContractRead } from "../scaffold-eth";

export const useRenderTokenSVG = (tokenId: number) => {
  const { data: svg } = useScaffoldContractRead({
    contractName: "SteveyWonder",
    functionName: "renderByTokenId",
    args: [BigInt(tokenId)],
  });

  return svg;
};
